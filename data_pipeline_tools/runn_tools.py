import os
import time
import pandas as pd
from data_pipeline_tools.auth import runn_headers_base
import requests

DEFAULT_MAX_ATTEMPTS = 5
# Network-level failures (timeouts, connection resets) are retried far more
# generously than HTTP error statuses. Since 2026-09-03 roughly one Runn
# request in four has stalled for exactly 135s or 270s before answering 200,
# so a stalled request is aborted after the request timeout and simply asked
# again. At a 26% stall rate, 5 attempts would abandon a page about once in
# every 3,000 requests, i.e. most 1,800-page walks of /actuals would die;
# 20 attempts makes that roughly one in 10^11.
DEFAULT_MAX_NETWORK_ATTEMPTS = 20
DEFAULT_PAGE_SIZE = 500
# Runn normally answers in 0.1-0.6s. 10s is ample headroom on the healthy
# path and turns a 135s/270s stall into a 10s cost plus one retry, instead of
# letting it eat the Cloud Run task timeout (see incidents 2026-09-01 and
# 2026-09-03..10). Override per job with RUNN_REQUEST_TIMEOUT_SECONDS.
REQUEST_TIMEOUT_SECONDS = 10


def request_timeout_seconds() -> float:
    return float(
        os.environ.get("RUNN_REQUEST_TIMEOUT_SECONDS", REQUEST_TIMEOUT_SECONDS)
    )


def reference_value_get(reference_name: str, references: list):
    reference_value = ""

    for row in references:
        if row["referenceName"] == reference_name:
            reference_value = row["externalId"]

    return reference_value


def handle_runn_rate_limits(response):
    rate_limit_remaining = int(response.headers.get("x-ratelimit-remaining", 1))
    rate_limit_reset = int(response.headers.get("x-ratelimit-reset", 0))
    retry_after = int(response.headers.get("retry-after", 0))

    if rate_limit_remaining == 0:
        wait_time = max(rate_limit_reset, retry_after)
        print(f"Rate limit reached. Waiting for {wait_time} seconds.")
        time.sleep(wait_time)


def page_get(
    url,
    headers,
    page_size,
    attempt=0,
    max_attempts=DEFAULT_MAX_ATTEMPTS,
    network_attempt=0,
):
    try:
        response = requests.get(
            url=url, headers=headers, timeout=request_timeout_seconds()
        )
    except requests.exceptions.RequestException as e:
        if network_attempt >= DEFAULT_MAX_NETWORK_ATTEMPTS:
            raise Exception(
                f"Max attempts {DEFAULT_MAX_NETWORK_ATTEMPTS} exceeded: request failed: {e}"
            ) from e
        print(f"(Attempt {network_attempt}) Request failed: {e}. Retrying..")
        return page_get(
            url,
            headers,
            page_size,
            attempt=attempt,
            max_attempts=max_attempts,
            network_attempt=network_attempt + 1,
        )

    if response.status_code == 200:
        print("OK")
        data = response.json()
        next_cursor = data.get("nextCursor")

        df = pd.DataFrame(data.get("values", []))

        if df.empty:
            return df, ""

        handle_runn_rate_limits(response)

        return df, next_cursor
    elif response.status_code == 429:
        print(f"Rate limit exceeded, attempt {attempt}")
        if attempt > max_attempts:
            raise Exception(
                f"Max attempts {max_attempts} exceeded: {response.status_code}, {response.text}"
            )
        handle_runn_rate_limits(response)
        return page_get(
            url, headers, page_size, attempt=attempt + 1, max_attempts=max_attempts
        )

    else:
        if attempt > max_attempts:
            raise Exception(
                f"Max attempts {max_attempts} exceeded: {response.status_code}, {response.text}"
            )

        print(
            f"(Attempt {attempt}) Status code {response.status_code} returned. Retrying.."
        )
        return page_get(
            url, headers, page_size, attempt=attempt + 1, max_attempts=max_attempts
        )


def fetch_all(token, base_url, service, page_size=DEFAULT_PAGE_SIZE):
    next_cursor = None
    has_more = True
    page_no = 0

    headers = runn_headers_base(token, service)

    while has_more:
        url = (
            f"{base_url}?cursor={next_cursor}&limit={page_size}"
            if next_cursor
            else f"{base_url}?limit={page_size}"
        )

        print(f"Page {page_no}, fetching {url}")
        page_df, next_cursor = page_get(url, headers, page_size)
        yield page_df
        page_no = page_no + 1

        if not next_cursor:
            has_more = False
            break

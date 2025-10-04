import time
import pandas as pd
from data_pipeline_tools.auth import runn_headers_base
import requests

DEFAULT_MAX_ATTEMPTS = 5
DEFAULT_PAGE_SIZE = 500


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
):
    response = requests.get(url=url, headers=headers)
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
        return page_get(url, headers, page_size, attempt=attempt + 1)

    else:
        if attempt > max_attempts:
            raise Exception(
                f"Max attempts {max_attempts} exceeded: {response.status_code}, {response.text}"
            )

        print(
            f"(Attempt {attempt}) Status code {response.status_code} returned. Retrying.."
        )
        return page_get(url, headers, page_size, attempt=attempt + 1)


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

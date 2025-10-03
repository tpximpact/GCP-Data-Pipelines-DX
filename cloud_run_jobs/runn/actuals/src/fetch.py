import pandas as pd
from data_pipeline_tools.auth import runn_headers_base
from data_pipeline_tools.runn_tools import handle_runn_rate_limits
import requests

MAX_ATTEMPTS = 5


def page_get(url, headers, attempt=0):
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
        if attempt > MAX_ATTEMPTS:
            raise Exception(
                f"Max attempts {MAX_ATTEMPTS} exceeded: {response.status_code}, {response.text}"
            )
        handle_runn_rate_limits(response)
        return page_get(url, headers, attempt=attempt + 1)

    else:
        if attempt > MAX_ATTEMPTS:
            raise Exception(
                f"Max attempts {MAX_ATTEMPTS} exceeded: {response.status_code}, {response.text}"
            )

        print(
            f"(Attempt {attempt}) Status code {response.status_code} returned. Retrying.."
        )
        return page_get(url, headers, attempt=attempt + 1)


def fetch_all(token):
    base_url = "https://api.runn.io/actuals/"
    limit = 500
    service = "Data Pipeline - Actuals"
    next_cursor = None
    has_more = True
    page_no = 0

    headers = runn_headers_base(token, service)

    while has_more:
        url = (
            f"{base_url}?cursor={next_cursor}&limit={limit}"
            if next_cursor
            else f"{base_url}?limit={limit}"
        )

        print(f"Page {page_no}, fetching {url}")
        page_df, next_cursor = page_get(url, headers=headers)
        yield page_df
        # df = pd.concat([df, page_df])
        page_no = page_no + 1

        if not next_cursor:
            has_more = False
            break

    # return df

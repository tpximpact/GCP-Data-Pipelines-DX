import os

from dotenv import load_dotenv

from data_pipeline_tools.runn_tools import fetch_all

load_dotenv()


runn_api_token = os.environ.get("RUNN_API_TOKEN")


def main() -> None:
    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/time-offs/holidays",
        service="Data Pipeline - Public Holidays",
        page_size=200,
    )

    first = next(pages)
    print(first.info())


if __name__ == "__main__":
    main()

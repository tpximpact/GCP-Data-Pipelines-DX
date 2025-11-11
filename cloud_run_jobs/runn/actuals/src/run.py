import os
from dotenv import load_dotenv
from data_pipeline_tools.runn_tools import fetch_all

load_dotenv()


RUNN_API_TOKEN = os.environ.get("RUNN_API_TOKEN")


def main():
    pages = fetch_all(
        token=RUNN_API_TOKEN,
        base_url="https://api.runn.io/actuals/",
        service="Data Pipeline - Actuals",
    )

    first = next(pages)
    print(first.info())


if __name__ == "__main__":
    main()

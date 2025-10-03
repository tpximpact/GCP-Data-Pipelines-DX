from .fetch import fetch_all
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()


runn_api_token = os.environ.get("RUNN_API_TOKEN")


def main():
    """
    Fetch all the actuals. Append to one large dataframe.

    Prints progress. Useful for debugging
    """
    bundle = pd.DataFrame([])

    pages = fetch_all(runn_api_token)

    first = next(pages)

    print(first.info())
    # for df in fetch_all(runn_api_token):
    #     bundle = pd.concat([bundle, df])
    #     print(bundle)


if __name__ == "__main__":
    main()


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
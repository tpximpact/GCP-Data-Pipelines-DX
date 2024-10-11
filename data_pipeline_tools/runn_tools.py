
def reference_value_get(reference_name: str, references: list):
  reference_value = ""

  for row in references:
    if row["referenceName"] == reference_name:
      reference_value = row["externalId"]

  return reference_value
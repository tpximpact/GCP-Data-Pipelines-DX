resource "google_pubsub_topic" "cloud_function_2am_trigger" {
  name         = "cloud-function-2am-trigger"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "nightly_at_two" {
  name        = "nightly-at-2am"
  description = "Scheduled daily to trigger cloud function at 2am"
  schedule    = "0 2 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_2am_trigger.id
    data       = base64encode("2am")
  }
}


resource "google_pubsub_topic" "cloud_function_3am_trigger" {
  name         = "cloud-function-3am-trigger"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "nightly_at_three" {
  name        = "nightly-at-3am"
  description = "Scheduled daily to trigger cloud function at 3am"
  schedule    = "0 3 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_3am_trigger.id
    data       = base64encode("3am")
  }
}


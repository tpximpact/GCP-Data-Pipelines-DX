resource "google_pubsub_topic" "cloud_function_nightly_trigger" {
  name         = "cloud-function-nightly-trigger"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "nightly_at_two" {
  name        = "nightly-at-2am"
  description = "Scheduled daily to trigger cloud function at 2am"
  schedule    = "0 2 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_nightly_trigger.id
    data       = base64encode("nightly")
  }
}

resource "google_pubsub_topic" "cloud_function_every_twelve_hours_trigger" {
  name         = "cloud-function-every-twelve-hours-trigger"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "every_twelve_hours" {
  name        = "every-twelve-hours"
  description = "Scheduled every 12 hours"
  schedule    = "0 */12 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_nightly_trigger.id
    data       = base64encode("daily")
  }
}

# --------------------------Legacy triggers--------------------------------\
resource "google_pubsub_topic" "cloud_function_trigger_cold" {
  name         = "cloud-function-trigger-cold"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id

}

resource "google_cloud_scheduler_job" "daily-5-45" {
  name        = "daily-5-45-trigger"
  description = "Scheduled daily to trigger cloud function at 5:45"
  schedule    = "*/45 5 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_trigger_cold.id
    data       = base64encode("weekly")
  }
}

resource "google_pubsub_topic" "cloud_function_trigger_hot" {
  name         = "cloud-function-trigger-hot"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "two-hourly-00" {
  name        = "every-two-hours-00"
  description = "Scheduled to trigger cloud function every two hours on the hour"
  schedule    = "0 */2 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_trigger_hot.id
    data       = base64encode("2hr")
  }
}

resource "google_pubsub_topic" "cloud_function_trigger_hot_2" {
  name         = "cloud-function-trigger-hot-2"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "two-hourly-15" {
  name        = "every-two-hours-15"
  description = "Scheduled to trigger cloud function every two hours 15 minutes past each hour"
  schedule    = "15 */2 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_trigger_hot_2.id
    data       = base64encode("2hr15")
  }
}

resource "google_pubsub_topic" "cloud_function_trigger_hot_15" {
  name         = "cloud-function-trigger-hot-15"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id
}

resource "google_cloud_scheduler_job" "trigger_15_minutes" {
  name        = "every-15-minutes"
  description = "Scheduled to trigger cloud function every 15 minutes"
  schedule    = "*/15 * * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_trigger_hot_15.id
    data       = base64encode("15")
  }
}


resource "google_pubsub_topic" "cloud_function_trigger_tester" {
  name         = "cloud-function-trigger-tester"
  kms_key_name = google_kms_crypto_key.pub_sub_key.id

}

resource "google_cloud_scheduler_job" "test-trigger" {
  name        = "test-trigger"
  description = "Scheduled daily to trigger cloud function at 5:45"
  schedule    = "*/45 5 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.cloud_function_trigger_tester.id
    data       = base64encode("weekly")
  }
}

class UniversityReviewNotificationRecipient
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/university_review_notification_recipients"
end

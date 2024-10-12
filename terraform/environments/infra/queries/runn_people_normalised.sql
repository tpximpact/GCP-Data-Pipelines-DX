SELECT
    runn_people.id as runn_id,
    runn_people.harvest_id,
    people_sheet.Hibob_ID as hibob_id,
    runn_people.firstName as first_name,
    runn_people.lastName as last_name,
    runn_people.email as email_address,
    people_sheet.Personal_Target AS personal_target,
    people_sheet.Team_Target AS team_target,
    people_sheet.Group as group_type,
    people_sheet.Team as team,
    people_sheet.Sub_Team as sub_team,
    runn_people.isArchived as is_archived
FROM `Runn_Raw.people` AS runn_people
LEFT JOIN `Variable_Data_Input.People_sheet` AS people_sheet ON runn_people.email = people_sheet.Email
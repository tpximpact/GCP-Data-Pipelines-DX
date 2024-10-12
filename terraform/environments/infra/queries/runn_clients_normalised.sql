SELECT
    clients.id,
    clients.harvest_id,
    clients.name,
    client_list.hubspot_name,
    client_list.netsuite_name,
    client_list.sector,
    clients.isArchived as is_archived
FROM `tpx-dx-dashboards.Runn_Raw.clients` as clients
LEFT JOIN `tpx-dx-dashboards.Static_Data.client_list` AS client_list ON clients.name = client_list.runn_name
SELECT
    projects.id,
    projects.harvest_id,
    projects.name,
    projects.teamId AS team_id,
    projects.clientId AS client_id,
    projects.budget,
    projects.expensesBudget AS expenses_budget,
    CAST(startDates.startDate AS TIMESTAMP) AS start_date,
    CAST(endDates.endDate AS TIMESTAMP) AS end_date,
    projects.isTemplate AS is_template,
    projects.isArchived AS is_archived,
    projects.isConfirmed AS is_confirmed,
    projects.pricingModel AS pricing_model,
    projects.rateType AS rate_type,
    projects.project_type AS project_type,
    projects.rateCardId AS rate_card_id,
    CAST(projects.createdAt AS TIMESTAMP) AS created_at,
    CAST(projects.updatedAt AS TIMESTAMP) AS update_at
FROM `tpx-dx-dashboards.Runn_Raw.projects` AS projects
LEFT JOIN (
    SELECT
        projectId,
        MAX(startDate) AS endDate
    FROM `tpx-dx-dashboards.Runn_Raw.assignments`
    GROUP BY projectId
) AS endDates ON projects.id = endDates.projectId
LEFT JOIN (
    SELECT
        projectId,
        MIN(startDate) AS startDate
    FROM  `tpx-dx-dashboards.Runn_Raw.assignments`
    GROUP BY
        projectId
) AS startDates ON projects.id = startDates.projectId
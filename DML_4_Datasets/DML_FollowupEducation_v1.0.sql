select p.PersonId as Person_Id,fe.VisitDate as Encounter_Date,NULL as Encounter_ID,
mct.[Name]
as CounsellingType,
mctt.[Name] as CounsellingTopic,
fe.Comments

from dtl_FollowupEducation fe
inner join Patient p on p.ptn_pk=fe.Ptn_pk
inner join mst_CouncellingType mct on mct.ID=fe.CouncellingTypeId
inner join mst_CouncellingTopic mctt on mctt.ID=fe.CouncellingTopicId

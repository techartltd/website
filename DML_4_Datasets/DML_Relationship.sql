exec pr_OpenDecryptedSession
Select 
	
	P.PersonId as Index_Person_Id,
	PR.PersonId as Relative_Person_Id,
	CAST(DECRYPTBYKEY(R.FirstName) as varchar(100)) RelativeFirstName,
	CAST(DECRYPTBYKEY(R.MidName) as varchar(100)) as RelativeMiddleName
	,CAST(DECRYPTBYKEY(R.LastName) as varchar(100)) as  RelativeLastName
	,(Select Top 1	Name	From LookupItem LI	Where LI.Id = R.Sex)	RelativeSex
	,(Select Top 1	Name From LookupItem LI	Where LI.Id = PR.RelationshipTypeId) Relationship,
	PR.DeleteFlag as Voided
From Patient P
Inner Join PersonRelationship PR On P.Id = PR.PatientId
Inner Join Person R On R.Id = PR.PersonId
Inner Join Person PD On PD.Id = P.PersonId
Where p.DeleteFlag = 0
And PR.DeleteFlag = 0
And R.DeleteFlag = 0 
order by PR.PatientId desc
SELECT S.secretid
	,f.folderpath AS [Folder Path]
	,s.SecretName
	,st.SecretTypeName AS [Template]
	,ps.SecretName AS [Priv Secret]
	,ps.SecretID AS [Priv Secret ID]
	,pst.SecretTypeName AS [Priv Secret Template]
	,CASE 
		WHEN ps.Active = 0 THEN 'False'
		WHEN ps.Active = 1 THEN 'True'
	END AS [Priv Secret Active]
	,CASE 
		WHEN sr.AssociatedSecretType = 'p' THEN 'Privileged'
		WHEN sr.AssociatedSecretType = 'A' THEN concat('Associated: ',sr.[Order])
		ELSE concat('Other: ',sr.AssociatedSecretType)
	END AS [Association Type]
FROM tbSecretResetSecrets sr
	JOIN tbsecret s ON s.secretid = sr.secretid
	JOIN tbfolder f ON f.folderid = s.FolderId
	JOIN tbsecret ps ON ps.SecretID = sr.resetsecretid
	JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID
	JOIN tbSecretType pst ON ps.SecretTypeID = pst.SecretTypeID
WHERE s.active =1 
ORDER BY  8,2,3,9

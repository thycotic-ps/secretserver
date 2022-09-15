# Mixed OS Domain Scanner

## Process
Add both of the scritps to secret server tagged as **discovery scanner** type.

Configure **both** scripts as machine scanners.
![image](https://user-images.githubusercontent.com/11204251/108533772-f70aa000-729e-11eb-92f2-ef69d8aec9ea.png)
Both scanners should be set to consume **Organazational Unit** templates. The Windows sacnner should produce **Windows Computer** template objects and the non windows scanner **Computer** template objects

In the Account Scanners area add Windows Local Account and Unix Non-Daemon User scanners as normal.

## Challenges

_Noted from Slack discussions_.

- Many of the linux servers don't have a DNS name attribute in Active Directory. If the FQDN of the server is other than the discovery source's FQDN, the machine scan would fail as SS wouldn't be able to find the machine. Ask that those are updated with a DNS value in AD for machines failing as you go
- If the AD bridge is flakey at times it can cause issues with SS trying to perform discovery on the device(s)


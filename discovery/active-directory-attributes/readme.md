# Introduction

This script is provided as an example for capturing additional Active Directory attributes during Discovery. It does require utilizing Extensible Discovery options and therefore the scan template and the attributes (properties) you are pulling from Active Directory have to be a 1:1 match. In addition, if you want that data brought into the Secret then the Secret Template being used will need to match as well.

> **Note:** This will only bring in the AD attributes of newly created Secrets imported from the Discovery process.

## Prerequisites

- Discovery account must have access to query Active Directory
- Scanner template for AD account must match the attributes you are pulling from AD
- RSAT tools for AD need to be installed on the Distributed Engine
- Distributed Engine must have network access to the domain being discovered

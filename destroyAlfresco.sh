#!/bin/bash
docker stop alfresco
docker rm -v alfresco
docker stop pg-alfresco
docker rm -v pg-alfresco

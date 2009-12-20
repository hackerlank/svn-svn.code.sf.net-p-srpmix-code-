#!/bin/bash

#ENV
#Repository Base URL
REPOS_BASE_URL="http://anonsvn.jboss.org/repos"
#Repository Base URL
COMP_URL=""
#PackegeName (used by Sources)
PKG_NAME=""
#Pattern (trunk|tags pattern)
PATTERN=""


#template
#curl -silent ${REPOS_BASE_URL}/${COMP_NAME}/tags/ | grep ${BRANCH_PATTERN}|awk -F'"' '{print $2}'|awk -F'/' '{print "(prelcopy :package \"pkg\":branch "$1":command-line   "svn co "${REPOS_BASE_URL}/jbossas/tags/"$1 ":update false:generated-by \"manual\" )"}'


#######################
# jbossas trunk
#######################
COMP_URL="jbossas"
PKG_NAME="JBossEAP"
PATTERN="trunk"
cat <<EOS 
(prelcopy 	:package "$PKG_NAME"
		:branch "$PATTERN"
		:command-line "svn co ${REPOS_BASE_URL}/$COMP_URL/$PATTERN"
		:update #t
		:generated-by "${0##*/}" ) 
EOS
#######################

#######################
# jbossas tags
#######################
COMP_URL="jbossas"
PKG_NAME="JBossEAP"
PATTERN="JBPAPP_._._._GA"
for m in $(curl -silent ${REPOS_BASE_URL}/${COMP_URL}/tags/|sed -nre "s,.*href=\"(${PATTERN}[^\"]*)/\".*,\1,p")
do
cat <<EOS 
(prelcopy 	:package "$PKG_NAME"
		:branch "$m"
		:command-line "svn co ${REPOS_BASE_URL}/${COMP_URL}/tags/$m"
		:update #f
		:generated-by "${0##*/}" ) 
EOS
done
#######################


# #######################
# # Hibernate Core trunk
# #######################
# COMP_URL="hibernate/core"
# PKG_NAME="Hibernate-core"
# PATTERN="trunk"
# cat <<EOS 
# (prelcopy 	:package "$PKG_NAME"
# 		:branch "$PATTERN"
# 		:command-line "svn co ${REPOS_BASE_URL}/${COMP_URL}/$PATTERN"
# 		:update #t
# 		:generated-by "${0##*/}" ) 
# EOS
# #######################
# 
# #######################
# # Hibernate Core tags
# #######################
# COMP_URL="hibernate/core"
# PKG_NAME="Hibernate-core"
# PATTERN="JBOSS_EAP_._._._"
# for m in $(curl -silent ${REPOS_BASE_URL}/${COMP_URL}/tags/|sed -nre "s,.*href=\"(${PATTERN}[^\"]*)/\".*,\1,p")
# do
# cat <<EOS 
# (prelcopy 	:package "$PKG_NAME"
# 		:branch "$m"
# 		:command-line "svn co ${REPOS_BASE_URL}/${COMP_URL}/tags/$m"
# 		:update #f
# 		:generated-by "${0##*/}" ) 
# EOS
# done
# #######################
# 
# 
# #######################
# # Hibernate entitymanager tags
# #######################
# COMP_URL="hibernate/entitymanager"
# PKG_NAME="Hibernate-entitymanager"
# PATTERN="GA"
# for m in $(curl -silent ${REPOS_BASE_URL}/${COMP_URL}/tags/|sed -nre "s,.*href=\"(.*${PATTERN}[^\"]*)/\".*,\1,p")
# do
# cat <<EOS 
# (prelcopy 	:package "$PKG_NAME"
# 		:branch "$m"
# 		:command-line "svn co ${REPOS_BASE_URL}/${COMP_URL}/tags/$m"
# 		:update #f
# 		:generated-by "${0##*/}" ) 
# EOS
# done
# #######################
# 
# 
# #######################
# # Hibernate annotations tags
# #######################
# COMP_URL="hibernate/annotations"
# PKG_NAME="Hibernate-annotations"
# PATTERN="GA"
# for m in $(curl -silent ${REPOS_BASE_URL}/${COMP_URL}/tags/|sed -nre "s,.*href=\"(.*${PATTERN}[^\"]*)/\".*,\1,p")
# do
# cat <<EOS 
# (prelcopy 	:package "$PKG_NAME"
# 		:branch "$m"
# 		:command-line "svn co ${REPOS_BASE_URL}/${COMP_URL}/tags/$m"
# 		:update #f
# 		:generated-by "${0##*/}" ) 
# EOS
# done
# #######################
# 


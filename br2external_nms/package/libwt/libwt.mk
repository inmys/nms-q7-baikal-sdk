#############################################################
#
# libwt
#
#############################################################

LIBWT_VERSION = 3.3.6
LIBWT_SITE = https://github.com/kdeforche/wt/archive
LIBWT_SOURCE = $(LIBWT_VERSION).tar.gz
LIBWT_DEPENDENCIES = boost
LIBWT_INSTALL_STAGING = YES

LIBWT_CONF_OPTS += -DBUILD_EXAMPLES=OFF -DENABLE_LIBWTTEST=OFF -DENABLE_LIBWTDBO=OFF
#-DINSTALL_RESOURCES=OFF

$(eval $(cmake-package))

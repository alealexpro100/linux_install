#!/bin/bash

echo_gpge() {
	echo -e "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
	echo -e "gpgcheck=1\nenabled=1\n"
}

MIRROR_DIR="/mnt/mirror"
echo -e "[main]\nreposdir=$MIRROR_DIR/oraclelinux/configs\n"

mirror='https://yum.oracle.com/repo/OracleLinux/OL8'
for arch in 'x86_64' 'aarch64'; do
	echo -e "[ol8_baseos_latest_$arch]"
	echo -e "name=Oracle Linux 8 BaseOS Latest ($arch)"
	echo -e "baseurl=$mirror/baseos/latest/$arch"
	echo_gpge
	echo -e "[ol8_appstream_$arch]"
	echo -e "name=Oracle Linux 8 Application Stream ($arch)"
	echo -e "baseurl=$mirror/appstream/$arch"
	echo_gpge
	if [[ "$arch" == "x86_64" ]]; then
		echo -e "[ol8_addons_$arch]"
		echo -e "name=Oracle Linux 8 Addons ($arch)"
		echo -e "baseurl=$mirror/addons/$arch"
		echo_gpge
	fi
	echo -e "[ol8_developer_$arch]"
	echo -e "name=Oracle Linux 8 Development Packages ($arch)"
	echo -e "baseurl=$mirror/developer/$arch"
	echo_gpge
	if [[ "$arch" == "x86_64" ]]; then
		echo -e "[ol8_oracle_instantclient_$arch]"
		echo -e "name=Oracle Instant Client for Oracle Linux 8 ($arch)"
		echo -e "baseurl=$mirror/oracle/instantclient/$arch"
		echo_gpge
	fi
	if [[ "$arch" == "x86_64" ]]; then
		echo -e "[ol8_UEKR6_$arch]"
		echo -e "name=Latest Unbreakable Enterprise Kernel Release 6 for Oracle Linux 8 ($arch)"
		echo -e "baseurl=$mirror/UEKR6/$arch"
		echo_gpge
	fi
done


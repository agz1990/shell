include Rules.make


export lng=SEaDFGPiCpWdfhY
export TAR_EXCLUDE=lib*.a	update.cfg	.svn	data
	
TAR_DIRS :=$(ARCH)/$(PLATFORM)
MK_UPDATE=./make-updatepacket.sh
TRANS_TAR=./transtar.sh


all clean cleanall:
	make $@ -C app
	
target:
	if [ -d $(TAR_DIRS) ]; then \
		tar cvzf $@_$(PLATFORM).$(lng).tgz \
		 $(TAR_DIRS)/* \
		--transform="s|$(TAR_DIRS)/||g" \
		--transform="s|language/lang|language|g" \
		--transform="s|wav/wav|wav|g" \
		--exclude="LANGUAGE.[^$(lng)]" \
		--exclude="[^$(lng)]_*.wav" \
		--exclude lib*.a \
		--exclude .svn \
		--exclude update.cfg;\
	fi;	

#打包语言语音文件，打包后同名大小写将在同一目录下
target_update:
	if [ -d $(TAR_DIRS) -a -f $(MK_UPDATE) ]; then \
		$(MK_UPDATE) $@_$(PLATFORM)_$(TFT_SCREEN).tgz $(svnlog)  $(TAR_DIRS);\
	fi;

#打包语言语音文件，打包后同名大小写将在同一目录下
target_file:
	if [ -d $(TAR_DIRS) -a -f $(TRANS_TAR) ]; then \
		$(TRANS_TAR) $@_$(PLATFORM)_$(TFT_SCREEN).tgz $(TAR_DIRS);\
	fi;

target_nooption:
	if [ -d $(TAR_DIRS) -a -f $(TRANS_TAR) ]; then \
		$(TRANS_TAR) $@_$(PLATFORM)_$(TFT_SCREEN).tgz $(TAR_DIRS);\
	fi;

target_option:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz auto.sh busybox kill.sh mgcfg-arm app/* \
		commonres/* data/options.cfg drivers/* lib/* miniguires/* service/* \
		--exclude .svn --exclude=lib/libZKUtils.a --exclude=lib/libzkcrypt.a \
		--exclude app/softwaremng ; \
		echo Leaving directory $(ARCH)/$(PLATFORM); \ 
	fi;

target_mini:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		rm -rf lib/libaccesscontrol.so lib/libattstateinput.so lib/liblawfulday.so lib/libprinter.so; \
		rm -rf lib/librecordquery.so lib/libsms.so lib/libuseraccprivilege.so lib/libverify.so; \
		rm -rf lib/libverifyresult.so lib/libwiegand.so lib/libworkcode.so; \
		tar cvzf $@_$(PLATFORM).tgz auto.sh kill.sh mgcfg-arm app/* lib/* service/* \
		--exclude .svn --exclude=lib/libZKUtils.a --exclude=lib/libzkcrypt.a \
		--exclude app/softwaremng ; \
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;

target_app:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz commonres/* app/* --exclude .svn \
		--exclude=lib/libZKUtils.a --exclude=lib/libzkcrypt.a --exclude app/softwaremng ; \
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;

target_udisk1:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz commonres/* app/* data/options.cfg lib/app/* lib/device/* \
		lib/libzk* lib/libhubclient.so service/* --exclude .svn --exclude lib*.a \
		--exclude app/softwaremng ; \
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;
	
target_udisk2:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz auto.sh commonres/* app/* data/* lib/app/* lib/device/* \
		lib/libzk* lib/libhubclient.so lib/libcommuapi.so lib/libwinutil.so \
		service/* --exclude .svn --exclude=lib/libZKUtils.a --exclude=lib/libzkcrypt.a \
		--exclude app/softwaremng ; \
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;

#不升级用户数据及配置参数
target_udisk3:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz auto.sh commonres/* app/* data/* lib/app/* lib/device/* \
		lib/libzk* lib/libhubclient.so lib/libcommuapi.so lib/libwinutil.so \
		lib/libfpsensor.so lib/liblanguage.so \
		service/* --exclude options.cfg --exclude ZKDB.db --exclude ZKSystem.db \
		--exclude .svn --exclude LANGUAGE.* --exclude *.a --exclude app/softwaremng ; \
		mv $@_$(PLATFORM).tgz mtdblock.tgz; \
		tar cvzf main.tgz auto.sh mtdblock.tgz update.cfg ;\
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;
	
#不升级用户数据及配置参数、不升级资源文件
target_udisk4:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		tar cvzf $@_$(PLATFORM).tgz auto.sh app/* data/* lib/app/* lib/device/* \
		lib/libzk* lib/libhubclient.so lib/libcommuapi.so lib/libwinutil.so \
		lib/libfpsensor.so lib/liblanguage.so \
		service/* --exclude options.cfg --exclude ZKDB.db --exclude ZKSystem.db \
		--exclude .svn --exclude LANGUAGE.* --exclude *.a --exclude app/softwaremng \
		--exclude *.png --exclude *.gif --exclude *.jpg; \
		mv $@_$(PLATFORM).tgz mtdblock.tgz; \
		tar cvzf main.tgz auto.sh mtdblock.tgz update.cfg ;\
		echo Leaving directory $(ARCH)/$(PLATFORM); \
	fi;


build_lng:
	if [ -d $(ARCH)/$(PLATFORM) ]; then \
		cd $(ARCH)/$(PLATFORM); \
		find -type f -name "LANGUAGE.?" | xargs  tar -zcvf language_$(PLATFORM).tgz --transform="s|language/lang|language|g" --exclude .svn;\
	fi;

#find . -name "*.[ES]" | xargs tar -cvzf language.tgz
#find . -name "LANGUAGE.*" | xargs tar -cvzf language.tgz
#tar -zxvf zmm100_tft35_language.SE.tgz  --transform='s|LANGUAGE.\([a-z]\)|lang/LANGUAGE.\1|g'

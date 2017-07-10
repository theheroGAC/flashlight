#
#  Generic Makefile for
#  Henkaku projects
#
TARGET   	= flashlight
TITLE_ID 	= ARKSFLASH
TITLE    	= Flash Light

SRC_DIR     = source
OUT_DIR 	= build

SOURCES_C  	= $(shell find $(SRC_DIR) -name '*.c')
SOURCES_CPP	= $(shell find $(SRC_DIR) -name '*.cpp')
OBJS     	= $(SOURCES_C:%.c=%.o) $(SOURCES_CPP:%.cpp=%.o)

PREFIX  	= arm-vita-eabi
CC      	= $(PREFIX)-gcc
CXX 	 	= $(PREFIX)-g++
STRIP 	 	= $(PREFIX)-strip

CFLAGS  	= -Wl,-q -Wall -O3
CXXFLAGS 	= -g -fpermissive -std=c++11 -Wall
ASFLAGS 	= $(CFLAGS) $(CXXFLAGS)
PSVITAIP 	= 	10.0.63

LIBS 		= -lSceLibKernel_stub \
			  -lvita2d -lSceGxm_stub \
			  -lSceDisplay_stub -lSceSysmodule_stub \
			  -lSceCommonDialog_stub -lSceIme_stub \
			  -lSceAVConfig_stub -lScePower_stub \
			  -lScePgf_stub -lpng -ljpeg -lfreetype -lz -lm -lc \
			  -lSceCtrl_stub -lSceRegistryMgr_stub
			  
			  

all: $(OUT_DIR)/$(TARGET).vpk

%.vpk: $(OUT_DIR)/eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "$(TITLE)" $(OUT_DIR)/param.sfo
	vita-pack-vpk -s $(OUT_DIR)/param.sfo -b $(OUT_DIR)/eboot.bin \
		--add sce_sys/icon0.png=sce_sys/icon0.png \
		--add sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
	$(OUT_DIR)/$(TARGET).vpk

$(OUT_DIR)/eboot.bin: $(OUT_DIR)/$(TARGET).velf
	vita-make-fself $< $@

%.velf: %.elf
	vita-elf-create $< $@

$(OUT_DIR)/$(TARGET).elf: binfolder $(OBJS)
	$(CXX) $(ASFLAGS) $(OBJS) $(LIBS) -o $@

%.o: %.bmp
	$(PREFIX)-ld -r -b binary -o $@ $^
	
%.o: %.png
	$(PREFIX)-ld -r -b binary -o $@ $^
	
%.o: %.jpg
	$(PREFIX)-ld -r -b binary -o $@ $^
	
%.o: %.jpeg
	$(PREFIX)-ld -r -b binary -o $@ $^

clean:
	@rm -rf $(OUT_DIR) $(OBJS)

vpksend: $(OUT_DIR)/$(TARGET).vpk
	curl -T $(OUT_DIR)/$(TARGET).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: $(OUT_DIR)/eboot.bin
	curl -T $(OUT_DIR)/eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."

binfolder:
	@mkdir $(OUT_DIR) || true


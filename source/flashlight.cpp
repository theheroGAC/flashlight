/*
	
		Flash Light
		Playstation Vita [HENkaku Homebrew]
		
		
		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		
		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
		
		
		--->> flashlight.cpp
		
*/

#include <psp2/kernel/processmgr.h>
#include <psp2/registrymgr.h>
#include <psp2/avconfig.h>
#include <vita2d.h>

#include "gamepad.hh"



#define BACKLIGHT_MAX_VALUE 65536
bool programRun = true;















int main() {
	vita2d_init();
	vita2d_set_clear_color(RGBA8(0, 255, 0, 255));
	
	Gamepad &gamepad = *Gamepad::getInstance();
	
	// get current brightness
	int backlightValue = -1;
	if (sceRegMgrGetKeyInt("/CONFIG/DISPLAY/", "brightness", &backlightValue) <0)
		programRun = false;
	
	// set max brightness
	if (sceAVConfigSetDisplayBrightness(BACKLIGHT_MAX_VALUE))
		programRun = false;
	
	while (programRun) {
		sceKernelPowerTick(SCE_KERNEL_POWER_TICK_DEFAULT);
		
		// update gamepad
		gamepad.update();
		
		// check for close
		if (gamepad.checkPressed(SCE_CTRL_CIRCLE))
			programRun = false;
		
		vita2d_start_drawing();
		vita2d_clear_screen();
		
		// draw information
		// 
		
		vita2d_end_drawing();
		vita2d_swap_buffers();
		}
	
	// reset brightness
	sceAVConfigSetDisplayBrightness(backlightValue);
	vita2d_fini();
	
	return sceKernelExitProcess(0);
	}

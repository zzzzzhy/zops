/*
 *  Qxwlan E600G/E600GAC v2 board support
 *
 *  Copyright (C) 2017 Peng Zhang <sd20@qxwlan.com>
 *  Copyright (C) 2018 Piotr Dymacz <pepe2k@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License version 2 as published
 *  by the Free Software Foundation.
 */
#include <linux/gpio.h>
#include <linux/platform_device.h>

#include <asm/mach-ath79/ath79.h>
#include <asm/mach-ath79/ar71xx_regs.h>

#include "common.h"
#include "dev-eth.h"
#include "dev-gpio-buttons.h"
#include "dev-leds-gpio.h"
#include "dev-m25p80.h"
#include "dev-usb.h"
#include "dev-wmac.h"
#include "machtypes.h"
#include "pci.h"

#define ZBT_WE826Q_GPIO_LED_SYS		13
#define ZBT_WE826Q_GPIO_LED_WAN		4
#define ZBT_WE826Q_GPIO_LED_LAN1	16
#define ZBT_WE826Q_GPIO_LED_LAN2	15
#define ZBT_WE826Q_GPIO_LED_LAN3	14
#define ZBT_WE826Q_GPIO_LED_LAN4	11
#define ZBT_WE826Q_GPIO_LED_WIFI	12

#define ZBT_WE826Q_GPIO_BTN_RESET	17


#define ZBT_WE826Q_KEYS_POLL_INTERVAL	20 /* msecs */
#define ZBT_WE826Q_KEYS_DEBOUNCE_INTERVAL	(3 * ZBT_WE826Q_KEYS_POLL_INTERVAL)

static const char *zbt_we826q_part_probes[] = {
	"tp-link",
	NULL,
};

static struct flash_platform_data zbt_we826q_flash_data = {
	.part_probes	= zbt_we826q_part_probes,
};


static struct gpio_led zbt_we826q_leds_gpio[] __initdata = {
	{
		.name		= "zbt-we826q:green:lan1",
		.gpio		= ZBT_WE826Q_GPIO_LED_LAN1,
		.active_low	= 1,
	}, {
		.name		= "zbt-we826q:green:lan2",
		.gpio		= ZBT_WE826Q_GPIO_LED_LAN2,
		.active_low	= 1,
	}, {
		.name		= "zbt-we826q:green:lan3",
		.gpio		= ZBT_WE826Q_GPIO_LED_LAN3,
		.active_low	= 1,
	}, {
		.name		= "zbt-we826q:green:lan4",
		.gpio		= ZBT_WE826Q_GPIO_LED_LAN4,
		.active_low	= 1,
	}, {
		.name		= "zbt-we826q:green:wan",
		.gpio		= ZBT_WE826Q_GPIO_LED_WAN,
		.active_low	= 1,
	}, {
		.name		= "zbt-we826q:green:sys",
		.gpio		= ZBT_WE826Q_GPIO_LED_SYS,
		.active_low	= 1,
	},{
		.name		= "zbt-we826q:green:wlan",
		.gpio		= ZBT_WE826Q_GPIO_LED_WIFI,
		.active_low	= 1,
	},
};


static struct gpio_keys_button zbt_we826q_gpio_keys[] __initdata = {
	{
		.desc		= "Reset button",
		.type		= EV_KEY,
		.code		= KEY_RESTART,
		.debounce_interval = ZBT_WE826Q_KEYS_DEBOUNCE_INTERVAL,
		.gpio		= ZBT_WE826Q_GPIO_BTN_RESET,
		.active_low	= 1,
	},
};


static void __init zbt_we826q_common_setup(void)
{
	//u8 *mac = (u8 *) KSEG1ADDR(0x1f01fc00);
	u8 *ee = (u8 *) KSEG1ADDR(0x1fff1000);
	//u8 tmpmac[ETH_ALEN];

	ath79_register_m25p80(&zbt_we826q_flash_data);

	ath79_setup_ar933x_phy4_switch(false, false);

	ath79_register_mdio(0, 0x0);

	/* LAN */
	ath79_eth1_data.phy_if_mode = PHY_INTERFACE_MODE_GMII;
	ath79_eth1_data.duplex = DUPLEX_FULL;
	ath79_switch_data.phy_poll_mask |= BIT(4);
	ath79_init_mac(ath79_eth1_data.mac_addr,  ee+2, 2);
	ath79_register_eth(1);

	/* WAN */
	ath79_switch_data.phy4_mii_en = 1;
	ath79_eth0_data.phy_if_mode = PHY_INTERFACE_MODE_MII;
	ath79_eth0_data.duplex = DUPLEX_FULL;
	ath79_eth0_data.speed = SPEED_100;
	ath79_eth0_data.phy_mask = BIT(4);
	ath79_init_mac(ath79_eth0_data.mac_addr, ee+2, 3);
	ath79_register_eth(0);

	//ath79_init_mac(tmpmac, mac, 0);
	//ath79_register_wmac(ee, tmpmac);
	ath79_register_wmac(ee, NULL);
	ath79_register_pci();
	ath79_register_usb();
}

static void __init zbt_we826q_setup(void)
{
	zbt_we826q_common_setup();

	ath79_register_leds_gpio(-1, ARRAY_SIZE(zbt_we826q_leds_gpio),
				 zbt_we826q_leds_gpio);

	ath79_register_gpio_keys_polled(1, ZBT_WE826Q_KEYS_POLL_INTERVAL,
					ARRAY_SIZE(zbt_we826q_gpio_keys),
					zbt_we826q_gpio_keys);
}


MIPS_MACHINE(ATH79_MACH_ZBT_WE826Q, "ZBT-WE826Q", "Zbtlink ZBT-WE826Q",
	     zbt_we826q_setup);



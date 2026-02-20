; In Seasons, the "empty" byte is the bank number, while in ages, it's 0.
.if defined(ROM_AGES) && defined(REGION_US)
	.emptyfill $00
.endif
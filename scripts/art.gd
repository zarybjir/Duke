extends Node
## Veškerá grafika hry je zatím nakreslená jako "ASCII pixel art" přímo tady.
## Každé písmeno je jedna barva z palety PAL, tečka je průhledná.
## Postavy a předměty dostanou automaticky tmavý obrys (funkce make()).
## Později se dá kterákoliv textura nahradit PNG souborem (třeba z AI).

const OUTLINE := Color("1e140e")

const PAL := {
	"k": Color("2b1d14"), # tmavá
	"s": Color("e0a070"), # kůže
	"x": Color("f6c896"), # světlo na kůži
	"S": Color("b07040"), # stín kůže
	"h": Color("3a2416"), # vlasy
	"H": Color("6a4428"), # odlesk vlasů
	"f": Color("c8782a"), # kožešina
	"u": Color("e8a050"), # světlá kožešina
	"F": Color("8a4a1a"), # tmavá kožešina
	"c": Color("4a2a10"), # skvrny
	"w": Color("f4f0e0"), # bělmo
	"b": Color("6a3a1a"), # dřevo tmavé
	"B": Color("a0662e"), # dřevo
	"j": Color("c88a4a"), # dřevo světlé
	"g": Color("5aa83a"), # zelená
	"G": Color("3a7a2a"),
	"l": Color("9ad85a"),
	"t": Color("2a5a22"),
	"r": Color("d8402e"), # červená
	"R": Color("8e2020"),
	"y": Color("f0d050"),
	"p": Color("8a8a96"), # kámen
	"P": Color("55555f"),
	"q": Color("b8b8c4"),
	"Q": Color("dcdce4"),
	"d": Color("9a6a3a"), # hlína
	"D": Color("6a4422"),
	"e": Color("b8865a"),
	"o": Color("f08a30"),
	"O": Color("b85a18"),
	"m": Color("e0786a"), # maso
	"M": Color("a84838"),
	"n": Color("f2ead2"), # kost
	"N": Color("c8bea0"),
	"v": Color("9a68c0"), # pterodaktyl
	"V": Color("5e3c86"),
	"z": Color("c8a0e0"),
}

const PLAYER_TOP := [
	"......hhhhhh........",
	"....hhHhhhhhhh......",
	"...hhHHhhhhhhhh.....",
	"..hhhHhhhhhhhhhh....",
	"..hhhhhssssshhhh....",
	"..hhhhsxxssssshh....",
	"...hhhsxssswkss.....",
	"...hhhssssswkss.....",
	"...hhsssssssssSs....",
	"....hssssssSSss.....",
	".....sssskkkss......",
	"......SssssSS.......",
	".....uuffffuff......",
	"...ssufcffffcfss....",
	"..sxsuffffffffsxs...",
	"..ssSfffcffffffSs...",
	"...ssfFffffcfFfss...",
	"....FfffFffffFF.....",
	".....FcFFFcFFF......",
]
const LEGS_IDLE := [
	".....sss...sss......",
	".....sxs...sxs......",
	".....sSs...sSs......",
	"....bbbb..bbbb......",
	"....bbbbb.bbbbb.....",
]
const LEGS_RUN1 := [
	"....sss.....sss.....",
	"...sxs.......sxs....",
	"..sSs.........sSs...",
	".bbbb.........bbbb..",
	"....................",
]
const LEGS_RUN2 := [
	"......ssssss........",
	"......sxs.sS........",
	".......sSsS.........",
	"......bbbbbb........",
	"....................",
]
const LEGS_JUMP := [
	"....ssss..ssss......",
	"...sxs.....sxs......",
	"..bbb.......bbb.....",
	"....................",
	"....................",
]
const CLUB := [
	"...jBB..",
	"..jBBBB.",
	".jBbBBBB",
	".BBBBbBB",
	".BbBBBBb",
	"..BBBBb.",
	"...BbB..",
	"...jb...",
	"...Bb...",
	"...Bb...",
	"...Bb...",
	"...Bb...",
	"...Bb...",
	"...bb...",
]
const DINO_TOP := [
	"..............ggggg.....",
	".............glllggg....",
	".............gggwkgggg..",
	".............gggwkggggg.",
	".............ggggggggGg.",
	"......G......gggggrrrr..",
	".....GgG....ggggggnnn...",
	"....GggG...gggggggg.....",
	"...GgggGG.ggggggg.......",
	"..GggggggggggggGG.......",
	".GgggggggggggggGg.......",
	"GggGgggllllllggg.g......",
	".G..ggglllllllgg........",
	".....gggllllggg.........",
	"......GggggggG..........",
]
const DINO_LEGS1 := [
	"......gg....gg..........",
	".....GgG....GgG.........",
	".....kkk....kkk.........",
]
const DINO_LEGS2 := [
	"........gg.gg...........",
	".......GgG.GgG..........",
	".......kkk.kkk..........",
]
const PTERO1 := [
	"vV..................Vv..",
	".vvV..............Vvv...",
	"..vzvV..........Vvzv....",
	"...vvzvV......Vvzvv.....",
	"....vvvvvVVVVvvvvv......",
	"......vvVVVVVVVwk.......",
	"........VVVVVVVVooooo...",
	".........VVVVVV.........",
	"..........V..V..........",
]
const PTERO2 := [
	"........................",
	"........................",
	"........................",
	"........................",
	"........VVVVVVVwk.......",
	".....vvVVVVVVVVVooooo...",
	"...vvzvvVVVVVVvvzvv.....",
	".vvzvV...V..V....Vvzvv..",
	"vvV................Vvv..",
]
const MEAT := [
	"......mmmm..",
	"....mmmmmmm.",
	"...mmwmmmMmm",
	"...mwmmmmmMm",
	"...mmmmmMMMm",
	"....mmmMMMm.",
	"...nNmmmmm..",
	"..nN........",
	"nnN.........",
	"nNN.........",
	".N..........",
]
const BERRY := [
	"....G.G..",
	"...GlG...",
	"..rrGrr..",
	".rwrrrwr.",
	".rrrrrrR.",
	"rrwrRrrrR",
	"rrrrrwrR.",
	".rRrrrRR.",
	"..RRrRR..",
]
const EGG := [
	"...nnnn...",
	"..nwnnnn..",
	".nwnnyynn.",
	".nnnnyynN.",
	"nnyynnnnnN",
	"nnyynnnyyN",
	"nnnnnnnyyN",
	".nnnyynnN.",
	".NnnyynNN.",
	"..NNNNNN..",
]
const HEART := [
	".rr.rr..",
	"rwrrrrr.",
	"rrrrrrR.",
	"rrrrrRR.",
	".rrrRR..",
	"..rRR...",
	"...R....",
]
const HEART_EMPTY := [
	".PP.PP..",
	"PkkPkkP.",
	"PkkkkkP.",
	"PkkkkkP.",
	".PkkkP..",
	"..PkP...",
	"...P....",
]
const TILE_GRASS := [
	"gglgglggglgglggl",
	"glGgglgGgglggGgl",
	"gGGgGgGGgGgGGgGg",
	"GGdGGGdGGdGGGdGG",
	"dGddGddGddGddGdd",
	"ddddddDdddddddDd",
	"dDddeddddDdddedd",
	"ddddqpdddddDdddd",
	"dddDppDddddddddd",
	"ddddddddddeddDdd",
	"dddeddDDddqpdddd",
	"dDdddddddDppDddd",
	"ddddddDddddddddd",
	"ddDdeddddddddDdd",
	"dddddqpdddDddedd",
	"ddddDppDdddddddd",
]
const GRASS_FRINGE := [
	"..l....l..l...l.",
	".lg.l.lg..gl.lg.",
	"lggllgggllgglggl",
]
const TILE_DIRT := [
	"ddddDddddddddDdd",
	"dddeddddddDdeddd",
	"dDddddqpdddddDdd",
	"dddddDppDddddddd",
	"ddedddddddddeddd",
	"dddddddDdddqpddd",
	"dqpddddddddppDdd",
	"dppDddDddedddddd",
	"dddDddddddDddddd",
	"ddddddeddqpddddd",
	"ddDddddddppDdddD",
	"ddddddddDdddeddd",
	"dDdddqpddddddDdd",
	"dddddppDdddddddd",
	"ddedDdddddDdddqp",
	"ddddddddedddddpp",
]
const TILE_STONE := [
	"QqqqqqqpQqqqqqqp",
	"qppppppPqpppppPP",
	"qpppppPPqppppppP",
	"qppppppPqpppppPP",
	"qpppppppPqppppPP",
	"PPPPPPPPPPPPPPPP",
	"QqqqpQqqqqqqqpQq",
	"pppPqpppppppPqpp",
	"pppPqppppppppPqp",
	"ppppPqppppppppPq",
	"PPPPPPPPPPPPPPPP",
	"QqqqqqqqpQqqqqqq",
	"ppppppppPqpppppp",
	"pppppppppPqppppp",
	"pppppppppPqppppp",
	"PPPPPPPPPPPPPPPP",
]
const TILE_LOG := [
	"kkkkkkkkkkkkkkkk",
	"jBBjBBBBBjBBBBjB",
	"BbBBBBBbBBBBBbBB",
	"BBBBbBBBBBBbBBBB",
	"bbbbbbbbbbbbbbbb",
	"kkkkkkkkkkkkkkkk",
	"..kb........bk..",
	"..kb........bk..",
	"...k........k...",
]
const SPIKES := [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	"..n....n....n...",
	"..nN...nN...nN..",
	".nnN..nnN..nnN..",
	".nNN..nNN..nNN..",
	"nnnNNnnnNNnnnNN.",
	"nNNNNnNNNNnNNNN.",
	"PpppPPpppPPpppPP",
	"PPPPPPPPPPPPPPPP",
	"PPPPPPPPPPPPPPPP",
]
const TUFT := [
	".l..l.l.",
	".gl.gglg",
	"gGgggGgg",
]
const FLOWER := [
	".y.",
	"yry",
	".y.",
	".g.",
	"lg.",
]
const BONE := [
	"n.....n",
	"nnnnnnN",
	"N.....N",
]
const FERN := [
	"....g.......",
	"..g.gl..g...",
	".gl.glg.lg..",
	"..glgGglg...",
	"g..gGgGg..g.",
	"lg.gGGGg.gl.",
	".lggGGGggl..",
	"..gggGggg...",
]
const ROCK := [
	"...qqp..",
	".qQqppP.",
	"qQpppPPP",
	"ppppPPPP",
]

const SKY := ["3b6fb6", "4a86c5", "5d9dd2", "78b3d9", "9cc8dc", "c3d9d2", "e6dcb8", "f6d49a"]
const BAYER := [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

var player_idle: Texture2D
var player_run1: Texture2D
var player_run2: Texture2D
var player_jump: Texture2D
var club: Texture2D
var dino1: Texture2D
var dino2: Texture2D
var ptero1: Texture2D
var ptero2: Texture2D
var meat: Texture2D
var berry: Texture2D
var egg: Texture2D
var heart: Texture2D
var heart_empty: Texture2D
var tile_grass: Texture2D
var tile_dirt: Texture2D
var tile_stone: Texture2D
var tile_log: Texture2D
var grass_fringe: Texture2D
var spikes: Texture2D
var tuft: Texture2D
var flower: Texture2D
var bone: Texture2D
var fern: Texture2D
var rock: Texture2D
var sky: Texture2D


func _ready() -> void:
	player_idle = make(PLAYER_TOP + LEGS_IDLE)
	player_run1 = make(PLAYER_TOP + LEGS_RUN1)
	player_run2 = make(PLAYER_TOP + LEGS_RUN2)
	player_jump = make(PLAYER_TOP + LEGS_JUMP)
	club = make(CLUB)
	dino1 = make(DINO_TOP + DINO_LEGS1)
	dino2 = make(DINO_TOP + DINO_LEGS2)
	ptero1 = make(PTERO1)
	ptero2 = make(PTERO2)
	meat = make(MEAT)
	berry = make(BERRY)
	egg = make(EGG)
	heart = make(HEART)
	heart_empty = make(HEART_EMPTY, false)
	tile_grass = make(TILE_GRASS, false)
	tile_dirt = make(TILE_DIRT, false)
	tile_stone = make(TILE_STONE, false)
	tile_log = make(TILE_LOG, false)
	grass_fringe = make(GRASS_FRINGE, false)
	spikes = make(SPIKES, false)
	tuft = make(TUFT, false)
	flower = make(FLOWER, false)
	bone = make(BONE)
	fern = make(FERN, false)
	rock = make(ROCK)
	sky = _make_sky(480, 300)


## Převede pole řetězců na texturu. S outline=true přidá kolem 1px tmavý obrys.
func make(rows: Array, outline: bool = true) -> Texture2D:
	var pad := 1 if outline else 0
	var h: int = rows.size()
	var w: int = 1
	for r in rows:
		w = maxi(w, (r as String).length())
	var img := Image.create_empty(w + pad * 2, h + pad * 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in h:
		var line: String = rows[y]
		for x in line.length():
			var c: String = line[x]
			if PAL.has(c):
				img.set_pixel(x + pad, y + pad, PAL[c])
	if outline:
		var src := img.duplicate() as Image
		var iw := img.get_width()
		var ih := img.get_height()
		for y in ih:
			for x in iw:
				if src.get_pixel(x, y).a > 0.0:
					continue
				var near := false
				for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = x + o.x
					var ny: int = y + o.y
					if nx >= 0 and ny >= 0 and nx < iw and ny < ih and src.get_pixel(nx, ny).a > 0.0:
						near = true
						break
				if near:
					img.set_pixel(x, y, OUTLINE)
	return ImageTexture.create_from_image(img)


## Obloha s retro "ditheringem" – plynulý přechod jen z několika barev.
func _make_sky(w: int, h: int) -> Texture2D:
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var cols: Array[Color] = []
	for c in SKY:
		cols.append(Color(c))
	var n := cols.size()
	for y in h:
		var f := clampf(float(y) / (h * 0.78), 0.0, 1.0) * (n - 1)
		var i := mini(int(f), n - 2)
		var frac := f - i
		for x in w:
			var th: float = (BAYER[y % 4][x % 4] + 0.5) / 16.0
			img.set_pixel(x, y, cols[i + 1] if frac > th else cols[i])
	return ImageTexture.create_from_image(img)

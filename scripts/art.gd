extends Node
## Veškerá grafika hry je zatím nakreslená jako "ASCII pixel art" přímo tady.
## Každé písmeno je jedna barva z palety PAL, tečka je průhledná.
## Později se dá kterákoliv textura nahradit PNG souborem (třeba z AI).

const PAL := {
	"k": Color("2b1d14"), # obrys
	"s": Color("e0a070"), # kůže
	"S": Color("b07040"), # stín kůže
	"h": Color("3a2416"), # vlasy
	"f": Color("c8782a"), # kožešina
	"F": Color("8a4a1a"), # tmavá kožešina
	"w": Color("f4f0e0"), # bělmo
	"e": Color("1a1a1a"),
	"b": Color("6a3a1a"), # dřevo tmavé
	"B": Color("a0662e"), # dřevo
	"g": Color("5aa83a"), # zelená
	"G": Color("3a7a2a"),
	"l": Color("9ad85a"),
	"r": Color("d8402e"), # červená
	"R": Color("8e2020"),
	"y": Color("f0d050"),
	"p": Color("8a8a96"), # kámen
	"P": Color("55555f"),
	"q": Color("b8b8c4"),
	"d": Color("9a6a3a"), # hlína
	"D": Color("6a4422"),
	"o": Color("f08a30"),
	"m": Color("e0786a"), # maso
	"M": Color("a84838"),
	"n": Color("f2ead2"), # kost
	"v": Color("9a68c0"), # pterodaktyl
	"V": Color("5e3c86"),
}

const PLAYER_TOP := [
	"....hhhhhh......",
	"...hhhhhhhh.....",
	"..hhhssssshh....",
	"..hhsssswksh....",
	"..hhssssssss....",
	"...hssssSsss....",
	"....ssssss......",
	".....ssss.......",
	"...fFffffFf.....",
	"..sfffffffffs...",
	"..sffFffFfffs...",
	"...fffffffff....",
]
const LEGS_IDLE := [
	"....FfFFfFF.....",
	"....ss...ss.....",
	"....ss...ss.....",
	"...kkk...kkk....",
]
const LEGS_RUN1 := [
	"....FfFFfFF.....",
	"...ss.....ss....",
	"..ss.......ss...",
	".kkk.......kkk..",
]
const LEGS_RUN2 := [
	"....FfFFfFF.....",
	".....ss.ss......",
	".....ss.ss......",
	"....kkk.kkk.....",
]
const LEGS_JUMP := [
	"....FfFFfFF.....",
	"...sss..sss.....",
	"..kk.....kk.....",
	"................",
]
const CLUB := [
	"..BBB.",
	".BBBBB",
	".BbBBB",
	".BBBbB",
	"..BBB.",
	"..bB..",
	"..bB..",
	"..bB..",
	"..bB..",
	"..bB..",
]
const DINO_TOP := [
	"................",
	".........gggg...",
	"........gggggg..",
	"........ggwkgg..",
	"........gggggggg",
	"........ggggrrr.",
	"...g....gggggg..",
	"..gg...ggggg....",
	".gggggggggggG...",
	"gggGgggggggG....",
	".ggggllllggg....",
	"..gggllllgg.....",
	"...gggggggg.....",
]
const DINO_LEGS1 := [
	"....gg..gg......",
	"....gg..gg......",
	"...kkk.kkk......",
]
const DINO_LEGS2 := [
	"....gg...gg.....",
	"...gg.....gg....",
	"..kkk....kkk....",
]
const PTERO1 := [
	"vv..........vv..",
	".vvv......vvv...",
	"..vvvv..vvvv....",
	"...vvvVVvvv.....",
	"....VVVVVVVwo...",
	".....VVVVVVVooo.",
	"......VVVV......",
	"......V..V......",
]
const PTERO2 := [
	"................",
	"................",
	"................",
	"....vVVVVv......",
	"..vvVVVVVVVwo...",
	".vvv.VVVVVVVooo.",
	"vvv...VVVV.vvv..",
	"vv....V..V...vv.",
]
const MEAT := [
	".....mmm..",
	"...mmmmmm.",
	"..mmmMmmmm",
	"..mmmmmmMm",
	"...mmmmmm.",
	"..nnmmmm..",
	".nn.......",
	"nnn.......",
	".n........",
]
const BERRY := [
	"...G...",
	"..G....",
	".rrrr..",
	"rrwrrr.",
	"rrrrrr.",
	"rrrrRr.",
	".rrRr..",
]
const EGG := [
	"...nn...",
	"..nnnn..",
	".nnyynn.",
	".nnnnnn.",
	"nnynnnnn",
	"nnnnnyyn",
	"nnnnnnnn",
	".nnynnn.",
	"..nnnn..",
]
const HEART := [
	".rr.rr..",
	"rrrrrrr.",
	"rwrrrrr.",
	"rrrrrrr.",
	".rrrrr..",
	"..rrr...",
	"...r....",
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
	"lgllglglllgllglg",
	"gglggggglggggglg",
	"ggggGgggggGggggg",
	"GgGGgGGgGgGGgGGG",
	"dGdGdddGdddGdGdd",
	"ddddDddddddddDdd",
	"dddddddddDdddddd",
	"dDddddpdddddddDd",
	"dddddddddddDdddd",
	"ddddDddddddddddd",
	"dddddddDdddpdddd",
	"dpdddddddddddDdd",
	"ddddddDddddddddd",
	"dddDdddddddDdddd",
	"dddddddddpdddddd",
	"ddDddddddddddddD",
]
const TILE_DIRT := [
	"ddddDddddddddDdd",
	"dddddddddDdddddd",
	"dDddddpdddddddDd",
	"dddddddddddDdddd",
	"ddddDddddddddddd",
	"dddddddDdddpdddd",
	"dpdddddddddddDdd",
	"ddddddDddddddddd",
	"dddDdddddddDdddd",
	"dddddddddpdddddd",
	"ddDddddddddddddD",
	"ddddddddDddddddd",
	"dDdddpdddddddDdd",
	"dddddddddddddddd",
	"ddddDdddddDddddd",
	"dddddddddddddddd",
]
const TILE_STONE := [
	"qqqqqqqpqqqqqqqp",
	"qppppppPqpppppPP",
	"qpppppPPqppppppP",
	"qppppppPqpppppPP",
	"qpppppppPqppppPP",
	"PPPPPPPPPPPPPPPP",
	"qqqqpqqqqqqqqpqq",
	"pppPqpppppppPqpp",
	"pppPqppppppppPqp",
	"ppppPqppppppppPq",
	"PPPPPPPPPPPPPPPP",
	"qqqqqqqqpqqqqqqq",
	"ppppppppPqpppppp",
	"pppppppppPqppppp",
	"pppppppppPqppppp",
	"PPPPPPPPPPPPPPPP",
]
const TILE_LOG := [
	"kkkkkkkkkkkkkkkk",
	"BBBbBBBBBBbBBBBB",
	"BbBBBBBbBBBBBbBB",
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
	"................",
	"..q....q....q...",
	"..qP...qP...qP..",
	".qqP..qqP..qqP..",
	".qpP..qpP..qpP..",
	"qqppPqqppPqqppP.",
	"qpppPqpppPqpppP.",
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
	".g.",
]
const BONE := [
	"n.....n",
	"nnnnnnn",
	"n.....n",
]

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
var spikes: Texture2D
var tuft: Texture2D
var flower: Texture2D
var bone: Texture2D


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
	heart_empty = make(HEART_EMPTY)
	tile_grass = make(TILE_GRASS)
	tile_dirt = make(TILE_DIRT)
	tile_stone = make(TILE_STONE)
	tile_log = make(TILE_LOG)
	spikes = make(SPIKES)
	tuft = make(TUFT)
	flower = make(FLOWER)
	bone = make(BONE)


## Převede pole řetězců na texturu.
func make(rows: Array) -> Texture2D:
	var h: int = rows.size()
	var w: int = 1
	for r in rows:
		w = maxi(w, (r as String).length())
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in h:
		var line: String = rows[y]
		for x in line.length():
			var c: String = line[x]
			if PAL.has(c):
				img.set_pixel(x, y, PAL[c])
	return ImageTexture.create_from_image(img)

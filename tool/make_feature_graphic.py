"""Draws the 1024x500 Play Store feature graphic into store/. Run from the repo root."""
from PIL import Image, ImageDraw, ImageFont
W,H=1024,500; S=2
AMBER=(255,137,6); MAGENTA=(229,49,112); INK=(15,14,23)
img=Image.new('RGB',(W*S,H*S),INK)
# soft diagonal glow from amber to magenta on the right half
glow=Image.new('RGB',(W*S,H*S))
px=[]
for x in range(W*S):
    t=x/(W*S-1)
    px.append(tuple(int(AMBER[k]+(MAGENTA[k]-AMBER[k])*t) for k in range(3)))
row=Image.new('RGB',(W*S,1)); row.putdata(px); glow=row.resize((W*S,H*S))
img=glow
d=ImageDraw.Draw(img)
icon=Image.open('assets/icon/icon_1024.png').convert('RGBA').resize((320*S,320*S),Image.LANCZOS)
mask=Image.new('L',icon.size,0); ImageDraw.Draw(mask).rounded_rectangle((0,0,icon.size[0]-1,icon.size[1]-1),radius=72*S,fill=255)
# drop shadow
sh=Image.new('RGBA',img.size,(0,0,0,0)); ImageDraw.Draw(sh).rounded_rectangle((84*S,100*S,404*S,420*S),radius=72*S,fill=(0,0,0,90))
from PIL import ImageFilter
sh=sh.filter(ImageFilter.GaussianBlur(18*S)); img=Image.alpha_composite(img.convert('RGBA'),sh)
img.paste(icon,(76*S,90*S),mask)
d=ImageDraw.Draw(img)
f1=ImageFont.truetype('/usr/share/fonts/truetype/lato/Lato-Black.ttf',104*S)
f2=ImageFont.truetype('/usr/share/fonts/truetype/lato/Lato-Bold.ttf',34*S)
f3=ImageFont.truetype('/usr/share/fonts/truetype/lato/Lato-Medium.ttf',28*S)
x=450*S
d.text((x,120*S),'SurJam',font=f1,fill='white')
d.text((x,258*S),'15 Indian & Western instruments',font=f2,fill='white')
d.text((x,312*S),'Lessons  ·  Tuner  ·  Record & share',font=f3,fill=(255,255,255,225))
img.convert('RGB').resize((W,H),Image.LANCZOS).save('store/feature_graphic.png')

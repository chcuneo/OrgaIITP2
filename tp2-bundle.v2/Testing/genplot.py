import os
from pylab import *
#TODO Pasar datos a otro directorio asi no se reprocesa
datadir = "./outputdata/"
plotdir = "./plots/"
if not os.path.exists(plotdir):
    os.makedirs(plotdir)
for filen in os.listdir(datadir):
	cO0time = []
	cO0size = []
	cO3time = []
	cO3size = []
	asm1time = []
	asm1size = []
	asm2time = []
	asm2size = []
	data = open(datadir + filen, "rU")
	for line in data:
		sample = line.split(", ", 2)
		if len(sample) == 3:
			if sample[0] == "cO0":
				cO0size.append(int(sample[1]))
				cO0time.append(int(sample[2][:-2]))
			if sample[0] == "cO3":
				cO3size.append(int(sample[1]))
				cO3time.append(int(sample[2][:-2]))
			if sample[0] == "asm1":
				asm1size.append(int(sample[1]))
				asm1time.append(int(sample[2][:-2]))
			if sample[0] == "asm2":
				asm2size.append(int(sample[1]))
				asm2time.append(int(sample[2][:-2]))
	plot(cO3size, cO3time, color='red', lw=2, label='CO3')
	plot(cO0size, cO0time, color='pink', lw=2, label='CO0')
	plot(asm1size, asm1time, color='green', lw=2, label='ASM1')
	plot(asm2size, asm2time, color='blue', lw=2, label='ASM2')
	legend(loc='upper left')
	xlabel('Width in pixels')
	ylabel('Cicles')
	getdataname = filen.split(".", 1)
	title(getdataname[0])
	grid(True)
	savefig(plotdir + getdataname[0] + ".png")
	clf()
import sys
from nb2wp import nb2wp
fullname = sys.argv[1]
urlPrefix = sys.argv[2]
outdir = 'html/' + fullname.split(".")[0]
nb2wp(fullname, out_dir=outdir,  remove_attrs=False,img_url_prefix=urlPrefix)
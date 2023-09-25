paths.cmo :
paths.cmx :
queueop.cmo :
queueop.cmx :
xs.cmo : \
    xst.cmi \
    xsraw.cmi \
    paths.cmo \
    xs.cmi
xs.cmx : \
    xst.cmx \
    xsraw.cmx \
    paths.cmx \
    xs.cmi
xs.cmi : \
    xst.cmi \
    xsraw.cmi
xsraw.cmo : \
    queueop.cmo \
    xsraw.cmi
xsraw.cmx : \
    queueop.cmx \
    xsraw.cmi
xsraw.cmi :
xst.cmo : \
    xsraw.cmi \
    xst.cmi
xst.cmx : \
    xsraw.cmx \
    xst.cmi
xst.cmi : \
    xsraw.cmi

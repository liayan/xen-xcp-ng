op.cmo : \
    op.cmi
op.cmx : \
    op.cmi
op.cmi :
packet.cmo : \
    partial.cmi \
    op.cmi \
    packet.cmi
packet.cmx : \
    partial.cmx \
    op.cmx \
    packet.cmi
packet.cmi : \
    partial.cmi \
    op.cmi
partial.cmo : \
    op.cmi \
    partial.cmi
partial.cmx : \
    op.cmx \
    partial.cmi
partial.cmi : \
    op.cmi
xb.cmo : \
    xs_ring.cmo \
    partial.cmi \
    packet.cmi \
    op.cmi \
    xb.cmi
xb.cmx : \
    xs_ring.cmx \
    partial.cmx \
    packet.cmx \
    op.cmx \
    xb.cmi
xb.cmi : \
    partial.cmi \
    packet.cmi \
    op.cmi
xs_ring.cmo :
xs_ring.cmx :

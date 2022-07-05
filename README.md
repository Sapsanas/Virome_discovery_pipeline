# Virome_discovery_pipeline

Read QC, assembly & virome discovery pipeline for Garmaeva et al. 2021,
Stability of the human gut virome and effect of gluten-free diet

https://doi.org/10.1016/j.celrep.2021.109132

The order:

1) Reads quality control & assembly per sample

2) Running different criteria (can be done in parallel):
- pVOGs search
- VirSorter
- aligning to viral references
- topology
- dark matter 
- RNA viruses search

3) Compiling putative viral scaffolds

RMD_LEC = $(wildcard lectures/lecture*.Rmd)
HTML_LEC = $(patsubst lectures/%.Rmd, docs/%.html, $(RMD_LEC))

RMD_SITE = $(wildcard site/*.Rmd)
HTML_SITE = $(patsubst site/%.Rmd, docs/%.html, $(RMD_SITE))

RMD_TUTO = $(wildcard practicals/TD*.Rmd)
HTML_TUTO = $(patsubst practicals/%.Rmd, docs/%_question.html, $(RMD_TUTO))
HTML_TUTO_SOL = $(patsubst practicals/%.Rmd, docs/%_solution.html, $(RMD_TUTO))

$(info Building the docs folder for github-pages)

all : lectures tutorials site
	$(info The site is now in the docs folder)

lectures : $(HTML_LEC)

tutorials : $(HTML_TUTO) $(HTML_TUTO_SOL)

site : $(HTML_SITE)

docs/lecture%.html : lectures/lecture%.Rmd
	touch lectures/index.Rmd
	cp site/_site.yml lectures/_site.yml
	Rscript -e "rmarkdown::render_site(input = '$<', encoding = 'UTF-8')" || (rm lectures/_site.yml; echo >&2 "Failed to build lectures"; false)
	rm lectures/_site.yml

docs/TD%_question.html : practicals/TD%.Rmd
	touch practicals/index.Rmd
	cp site/_site.yml practicals/_site.yml
	cp site/_output.yaml.TD practicals/_output.yaml
	Rscript -e "rmarkdown::render_site(input = '$<', encoding = 'UTF-8', output_format = 'unilur::tutorial_html')" || (rm practicals/_site.yml practicals/_output.yaml practicals/index.Rmd; echo >&2 "Failed to build practicals"; false)
	rm practicals/_site.yml practicals/_output.yaml practicals/index.Rmd

docs/TD%_solution.html : practicals/TD%.Rmd
	touch practicals/index.Rmd
	cp site/_site.yml practicals/_site.yml
	cp site/_output.yaml.TD practicals/_output.yaml
	Rscript -e "rmarkdown::render_site(input = '$<', encoding = 'UTF-8', output_format = 'unilur::tutorial_html_solution')" || (rm practicals/_site.yml practicals/_output.yaml practicals/index.Rmd; echo >&2 "Failed to build practicals solutions"; false)
	rm practicals/_site.yml practicals/_output.yaml practicals/index.Rmd

docs/%.html : site/%.Rmd site/_site.yml
	touch docs/.nojekyll
	Rscript -e "rmarkdown::render_site(input = '$<', encoding = 'UTF-8')"

clean :
	rm -rf docs/*
	rm -f practicals/_site.yml practicals/_output.yaml practicals/index.Rmd lectures/_site.yml
	$(info The docs folder is now empty)

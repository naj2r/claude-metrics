---
title: Software
permalink: /software/
layout: splash
---


# Stata coding guide
My [Stata Coding Guide](/guide) describes how to set up a robust coding environment and write a "push-button" analysis that reproduces all results from raw data. The guide includes a companion [replication package](https://github.com/reifjulian/my-project) that can serve as a template for other research projects.

# Multiple hypothesis testing
My Stata command `wyoung` (coauthored with Damon Jones and David Molitor) adjusts *p*-values for the number of hypotheses being tested. For usage instructions, follow the instructions and examples in the Stata help file or the `wyoung` [GitHub repository](https://github.com/reifjulian/wyoung). For details about the algorithm we employ, consult the [technical documentation](/wyoung/documentation/wyoung.pdf), which includes results from numerical simulations. See [Jones, Molitor, and Reif (2019)](/research/reif.qje.2019.wellness.pdf) and [Reif et al. (2020)](/research/reif.jamaim.2020.wellness.pdf) for examples of how to use `wyoung` in research.

# Software packages
Source code and installation instructions for all my software packages are available on [GitHub](https://github.com/reifjulian). Stata packages can be installed using the `ssc` command. For example, type `ssc install regsave, replace` at the Stata prompt to install the `regsave` package. To install the latest version of all my Stata packages, execute the following code:
```stata
foreach cmd in appendfile autorename dobatch regsave rscript sortobs strgroup svret texsave wyoung {

  ssc install `cmd', replace
  
  * Uncomment the following line to install the latest developer's version
  *net install `cmd', from("https://raw.githubusercontent.com/reifjulian/`cmd'/master") replace
}
```


## Package descriptions

{:class="table table-bordered " style="vertical-align: middle"}
<table>
  {% for row in site.data.software %}
    {% if forloop.first %}
	  <thead>
      <tr>
      {% for pair in row %}
        <th>{{ pair[0] | font_modify: 'weight', 'bold'}}</th>
      {% endfor %}
      </tr>
	  </thead>
    {% endif %}

    {% tablerow pair in row %}
      {{ pair[1] | markdownify}}
    {% endtablerow %}
  {% endfor %}
</table>




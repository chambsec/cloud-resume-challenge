# Frontend Tech Specs

- Create a static website that serves an html resume

## Resume Format Considerations

I line in New Jersey and my resume should be downloadable in word/pdf format excluding photos. 

I will be using the [Harvard Resume Template](https://careerservices.fas.harvard.edu/resources/harvard-college-guide-to-resumes-cover-letters/) as the basis of my Resume 

## Harvard Resume Format


I know HTML very, so I'm going to let GenAI do the grunt work and generate out the html and possibly CSS. I will manaully refactor the code to my personal standard. 

Prompt to Chatgpt 5:

```text
Convert this resume format into html.
Please don't use a css framework.
Please use the least amount of css tags.
```


Image provided to llm:
 ![](./docs/harvard%20resume%201.jpg)


This is the [generated output](./docs/Nov-29-25-resume.html) which I will adjust accordingly.

This is what the generated HTML looks like unaltered:

![](./docs/resume%20renered.jpg)


## HTML Changes

- UTF 8 will support most languages. 
- I plan on applying mobile styling to my website so I'll inlcude the viewport metatag.
- CSS styles will be extracted into its own stylesheet one I'm happy with the results.
- HTML markup will be simplified to me as minimial as possible. 
- I'lee be using soft tabs two spaces because I prefer coding in ruby and thats standard tab format 
This product produces the result by scraping the following websites
	1. SimilarWeb
	2. ScanBackLinks
	3. Twitter
	4. Whois
	5. Gravatar
	6. WebHostingHero
	7. WordPress
	8. RestApi for Users Detail
	9. Advertisment for checking whether the site contains following pages(deal, advert, coupon, giveaway, offer, podcast)
	10 ExtractEmail for extracting emails from the index, contact and about page of the website

For running the software first setup the rails environment.

	After setting up the environment, run the command as per the website. Description provided below for each website.
		a) rake website_name:fetch inputfile="file_name_with_location" outputfile="file_name_with_location"
		b) After step (a) gets completed it will display the task_id. Note down that task_id
		c) Run resque workers till all jobs of that task gets completed
		d) rake website_name:output task_id="noted_in-step_b"
		e) your output file will be made after the completion of the above task

	website_name for different websites used in steps below
		For SimilarWeb : similar_web
		For ScanBackLinks : scan_back_links
		For Twitter : twitter
		For Whois : whois
		For Gravatar : gravatar
		For WebHostingHero : web_hosting_hero
		For WordPress : word_press
		For RestApi : rest_api
		For Advertisment : advertisment
		For ExtractEmail : extract_email

		Ex:- For SimilarWeb

		a) rake similar_web:fetch inputfile="/home/user/website.txt" outputfile="/home/user/similarweb.csv"
				It will display something like
				1  															# => task_id
				SIMILARWEB											# => Category
		b)	run resque:workers till all jobs get modified
		c)	rake similar_web:output task_id="1"
		d) 	Your Output file is generate with name similarweb.csv at location /home/user/

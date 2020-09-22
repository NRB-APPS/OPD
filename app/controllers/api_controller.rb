class ApiController < GenericApplicationController

  skip_before_filter :authenticate_user!, :set_current_user, :location_required

  def malaria_dashboard

    results = {}

    cur_date = params[:date].to_date rescue Date.today
    date_ranges = {
        "Today" => [cur_date, cur_date],
        "This Month" => [cur_date.beginning_of_month, cur_date.end_of_month],
        "This Quarter" => [cur_date.beginning_of_quarter, cur_date.end_of_quarter],
        "This Year" => [cur_date.beginning_of_year, cur_date.end_of_year]
    }

    #Usage:
    #{"key" => "api method to call"}
    data_sources = {
        "reported_cases" => "malaria_observations",
        "microscopy_orders" => "microscopy_orders",
        "microscopy_positives" => "microscopy_positives",
        "microscopy_negatives" => "microscopy_negatives",
        "microscopy_unknown" => "microscopy_unknown",
        "mRDT_orders" => "mRDT_orders",
        "mRDT_positives" => "mRDT_positives",
        "mRDT_negatives" => "mRDT_negatives",
        "mRDT_unknown" => "mRDT_unknown",
        "under_five_males" => "under_five_malaria_cases_male",
        "under_five_females" => "under_five_malaria_cases_female",
        "treated_negatives" => "treated_negatives",
        "all_dispensations" => "all_dispensations",
        "first_line_dispensations" => "first_line_dispensations",
        "malaria_in_pregnancy" => "malaria_in_pregnancy"
    }

    date_ranges.each do |category, date_range|
      results[category] = {}
      data_sources.each do |indicator, query|
        start = Time.now
        results[category][indicator] = eval("API.#{query}('#{date_range[0].to_s}', '#{date_range[1].to_s}').count")
        sec = (Time.now - start).to_i
        puts "Category: #{category}, Query: #{query}, #{sec/60} Min #{sec%60} Sec"

      end
    end

    start = Time.now
    results['dispensation_trends'] = API.dispensation_trends((cur_date - 1.year), cur_date)
    sec = (Time.now - start).to_i
    puts "Query: dispensation trends, #{sec/60} Min #{sec%60} Sec"

    render :text => results.to_json
  end

	def ocr_demographics

		remote_data = ["P19292929292", "TestFirstName", "TestMiddleName", "Kapundi", "12/Jan/2001", "M", "Area 23"]
		data = {
			"npid" => remote_data[0],
			"first_name" => remote_data[1],
			"middle_name" => remote_data[2],
			"last_name"  => remote_data[3],
			"dob"		 => remote_data[4],
			"gender"	=> remote_data[5],
			"address"	=>	remote_data[6]
		}

		File.open("tmp/ocr_data.json", "w"){|f| f.write(data.to_json)}
		render :layout => false, :text => true
	end

	def check_for_ocr_data
			
		if File.exists?("tmp/ocr_data.json")
			data = File.read("tmp/ocr_data.json")
			File.delete("tmp/ocr_data.json")

			render :layout => false, :text => data and return
		else
			render :layout => false, :text => false and return
		end			
	end

end

class OrientationsController < ApplicationController
  before_filter :load_course
  before_filter :login_required

  layout 'questionnaire_plain'
  
  def load_course
    @instance = CourseInstance.find(params[:course_instance_id])
    @course = @instance.course
  end

  def show
    redirect_to completed_course_instance_orientation_path(@instance) if Orientation.exists?(:user_id => current_user.id, :course_instance_id => @instance.id)
    
    @questions = [
"Minulle t&auml;rke&auml; tavoite opinnoissani on menesty&auml; paremmin kuin muut opiskelijat.",
"Tunnen itseni eritt&auml;in ep&auml;varmaksi ja hermostuneeksi, kun minun pit&auml;isi keskitty&auml; johonkin vaativaan tai vaikeaan teht&auml;v&auml;&auml;n.",
"Ongelmatilanteissa kokeilen mielell&auml;ni uusia strategioita ja ratkaisumenetelmi&auml;.",
"Minulle t&auml;rke&auml; tavoite on menesty&auml; opinnoissa hyvin.",
"Mielest&auml;ni on t&auml;rke&auml;&auml;, ett&auml; kursseilla voi opiskella itsen&auml;isesti.",
"Minulla ei ole tapanani suunnitella opintojani, vaan etenen p&auml;iv&auml; kerrallaan.",
"Oppitunneilla olen usein huolissani siit&auml;, etten ymm&auml;rr&auml; tai tied&auml; oikeita vastauksia.",
"Kokeilen mielell&auml;ni uusia keinoja erilaisten ongelmien ratkaisemiseksi.",
"Yrit&auml;n v&auml;ltt&auml;&auml; tilanteita, joissa saatan vaikuttaa kyvytt&ouml;m&auml;lt&auml; tai tyhm&auml;lt&auml;.",
"Minulle on t&auml;rke&auml;&auml; suunnitella hyvin miten aion edet&auml; opinnoissani.",
"Opiskelen oppiakseni uusia asioita.",
"Mielest&auml;ni on t&auml;rke&auml;&auml;, ett&auml; opettajilta saa palautetta kursseilla edistymisest&auml;.",
"Olen erityisen tyytyv&auml;inen, jos minun ei tarvitse tehd&auml; liikaa t&ouml;it&auml; opiskelun eteen.",
"Minusta on mukava ty&ouml;skennell&auml; sellaisten asioiden parissa, jotka voin tehd&auml; ohjeita noudattamalla.",
"Oppituntien tai tenttien aikana olen usein huolissani siit&auml;, ett&auml; menestyn huonommin kuin muut oppilaat.",
"Yrit&auml;n v&auml;ltt&auml;&auml; tilanteita, joissa voi ep&auml;onnistua tai tehd&auml; virheit&auml;.",
"Minulle t&auml;rke&auml; tavoite opinnoissani on hankkia uutta tietoa.",
"Olen huomannut, ett&auml; luovutan helposti, jos opiskeluun liittyv&auml;t teht&auml;v&auml;t ovat vaikeita.",
"Mielest&auml;ni on t&auml;rke&auml;&auml;, ett&auml; opiskeluteht&auml;vi&auml; voi tehd&auml; yhdess&auml; muiden opiskelijoiden kanssa.",
"Ongelmatilanteissa kokeilen mielell&auml;ni uusia strategioita ja ratkaisumenetelmi&auml;.",
"Yrit&auml;n selvit&auml; opinnoistani mahdollisimman v&auml;h&auml;ll&auml; ty&ouml;ll&auml;.",
"Se tuntuu hyv&auml;lt&auml;, jos onnistun n&auml;ytt&auml;m&auml;&auml;n muille opiskelijoille olevani kyvyk&auml;s.",
"Olen huomannut, ett&auml; minun on hyvin vaikea keskitty&auml; kunnolla, kun minun pit&auml;isi ty&ouml;skennell&auml; jonkin vaativan opiskeluteht&auml;v&auml;n parissa.",
"Minulle on t&auml;rke&auml;&auml;, etten ep&auml;onnistu muiden opiskelijoiden n&auml;hden.",
"Suunnittelen opintoni ja opiskeluaikatauluni tarkoin.",
"Minulle t&auml;rke&auml; tavoite opinnoissani on oppia mahdollisimman paljon.",
"Seuraan mielell&auml;ni tiettyj&auml; s&auml;&auml;nt&ouml;j&auml; tai ohjeita ratkaistessani ongelmia tai suorittaessani teht&auml;vi&auml;.",
"Minulle on t&auml;rke&auml;&auml;, ett&auml; saan hyvi&auml; arvosanoja.",
"Minulle on t&auml;rke&auml;&auml; se, ett&auml; muut pit&auml;v&auml;t minua kyvykk&auml;&auml;n&auml; ja osaavana.",
"Mielest&auml;ni on t&auml;rke&auml;&auml;, ett&auml; opinnoissa ja kursseilla voi edet&auml; omaan tahtiinsa.",
"Pid&auml;n ongelmista joita voin yritt&auml;&auml; ratkaista omalla tavallani.",
"Pyrin tekem&auml;&auml;n vain pakolliset opintoihini liittyv&auml;t asiat, enk&auml; yht&auml;&auml;n enemp&auml;&auml;.",
"Olen aina huolissani siit&auml;, ett&auml; ep&auml;onnistun tenteiss&auml;.",
"Tavoitteeni on menesty&auml; opinnoissani hyvin."

#"Olen motivoitunut suorittamaan t&auml;m&auml;n kurssin.",
#"Kurssin asioista on minulle paljon hy&ouml;ty&auml; jatkossa."
]
  end
  
  # POST /courses
  # POST /courses.xml
  def create
    @orientation = Orientation.new
    
    unless params[:questions]
      redirect_to course_instance_orientation_path(@instance)
      return
    end
    
    @orientation.user = current_user
    @orientation.course_instance = @instance
    @orientation.studentnumber = current_user.studentnumber
    @orientation.payload = params[:questions].to_json
    @orientation.save
    
    redirect_to completed_course_instance_orientation_path(@instance)
  end

  def completed
    redirect_to course_instance_orientation_path(@instance) unless Orientation.exists?(:user_id => current_user.id, :course_instance_id => @instance.id)
    
    @token = Digest::SHA1.hexdigest(current_user.studentnumber || '')
  end

end

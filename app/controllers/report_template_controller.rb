class ReportTemplateController < ApplicationController
  before_filter :super_authenticate

  def index
    @enable_preview = File.exist?(filename())
  end

  def upload
    file = params[:pdffile]

    output_path = filename()
    File.open(output_path,'wb') do |out_file|
      out_file.write(file.read)
    end

    flash[:notice] = 'PDF template saved'
    redirect_to action: :index
  end

  def preview
    Java::OrgRsnaIsnUtil::Reports.preview()
    send_file preview_filename, type: 'application/pdf', disposition: :inline
  end

  protected
  def filename
    File.join([(ENV['RSNA_ROOT'] || "").strip,'conf','pdf-template.pdf'])
  end

  def preview_filename
    File.join([(ENV['RSNA_ROOT'] || "").strip,'report-preview.pdf'])
  end


end

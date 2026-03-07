class SubjectsController < ApplicationController
  def create
    @subject = Contact.new(subject_params)

    if @subject.save
      if params[:return_to].present?
        redirect_to build_morph_url(params[:return_to], :new_subject_id, @subject.id)
      else
        redirect_to root_path, notice: "Soggetto creato."
      end
    else
      redirect_to params[:return_to] || root_path, alert: "Errore."
    end
  end

  private
    def subject_params
      params.require(:contact).permit(:first_name, :last_name, :kind)
    end
end

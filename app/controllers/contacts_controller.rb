class ContactsController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy ]

  def index
    @total_contacts = Contact.count
    @contacts = ContactQuery.new(Contact.all, params).resolve

    @pagy, @contacts = pagy(@contacts)
  end

  def show
    @total_contact_jobs = @contact.jobs.count
    @jobs = JobQuery.new(@contact.jobs, params).resolve

    @pagy, @jobs = pagy(@jobs)
  end

  def new
    @contact = Contact.new(kind: params[:kind].presence || "person")
    render layout: "modal"
  end

  def create
    @contact = Contact.new(contact_params)

    unless @contact.save
      render :new, layout: "modal", status: :unprocessable_entity
    end
  end

  def edit
    render layout: "modal"
  end

  def update
    unless @contact.update(contact_params)
      render :edit, layout: "modal", status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: "Contatto eliminato.", status: :see_other
  end

  private
    def set_contact
      @contact = Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(
        :kind,
        :first_name, :last_name,
        :company_name,
        :phone, :email, :vat_number, :tax_id
      )
    end
end

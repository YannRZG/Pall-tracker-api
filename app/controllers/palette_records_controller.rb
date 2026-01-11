class PaletteRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Tous les records liés à l'entreprise de l'utilisateur
    records = PaletteRecord
                .where(company: current_user.company)
                .includes(carrier: :company, shipper: :company, recipient: :company)
                .order(week: :desc)

    render json: records.as_json(
      methods: [:loading_debt, :delivery_debt],
      include: {
        carrier: { only: [:id], include: { company: { only: [:name] } } },
        shipper: { only: [:id], include: { company: { only: [:name] } } },
        recipient: { only: [:id], include: { company: { only: [:name] } } }
      }
    )
  end

  def create
    # Si admin, peut créer pour n'importe quel shipper de sa company
    if current_user.admin?
      record = PaletteRecord.new(palette_params)
      record.company = current_user.company
    else
      # Sinon, l'utilisateur ne peut créer que pour lui-même
      record = current_user.palette_records.new(palette_params)
      record.company = current_user.company
    end

    if record.save
      render json: record, status: :created
    else
      render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    record = if current_user.admin?
               # Admin : peut modifier n'importe quel record de sa company
               current_user.company.palette_records.find(params[:id])
             else
               # Utilisateur normal : ne peut modifier que ses propres records
               current_user.palette_records.find(params[:id])
             end

    if record.update(palette_params)
      render json: record.as_json(methods: [:loading_debt, :delivery_debt]), status: :ok
    else
      render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def palette_params
    params.require(:palette_record).permit(
      :week, :date, :rendered, :loaded, :due, 
      :transport, :loading_point, :delivery_point, 
      :comment, :shipper_id, :recipient_id, :carrier_id
    )
  end
end

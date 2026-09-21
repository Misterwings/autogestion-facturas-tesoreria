import Swal from 'sweetalert2';
import 'sweetalert2/dist/sweetalert2.min.css';

export const confirmBatchDeletion = async (batch) => {
    const result = await Swal.fire({
        title: `¿Eliminar el lote #${batch.id}?`,
        text: `Se eliminarán permanentemente ${batch.source_file_name}, sus comprobantes, facturas y archivos asociados.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Sí, eliminar lote',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#dc2626',
        cancelButtonColor: '#334155',
        background: '#07111f',
        color: '#e2e8f0',
        focusCancel: true,
        reverseButtons: true,
    });

    return result.isConfirmed;
};

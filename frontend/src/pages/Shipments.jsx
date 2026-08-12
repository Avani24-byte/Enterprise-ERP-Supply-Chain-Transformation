import { useEffect, useState } from "react";
import { getShipments } from "../api/shipmentsApi";

export default function Shipments() {
  const [shipments, setShipments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchShipments = async () => {
      try {
        setLoading(true);
        const result = await getShipments();
        setShipments(result);
        setError(null);
      } catch (err) {
        console.warn("Shipments API not available yet:", err.message);
        setShipments([]);
        setError(null);
      } finally {
        setLoading(false);
      }
    };
    fetchShipments();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">Shipment Tracking</h1>
      <p className="text-gray-500 mt-2 mb-6">
        Shipment status and delivery tracking will appear here.
      </p>

      {loading && (
        <p className="text-gray-500 text-sm mb-4">Loading shipments...</p>
      )}
      {!loading && shipments.length === 0 && (
        <p className="text-gray-400 text-xs mb-4">
          No shipment records available yet.
        </p>
      )}
    </div>
  );
}

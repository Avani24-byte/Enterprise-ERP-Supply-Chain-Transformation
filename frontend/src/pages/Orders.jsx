import { useEffect, useState } from "react";
import SalesOrderForm from "../components/SalesOrderForm";
import { getOrders } from "../api/ordersApi";

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchOrders = async () => {
      try {
        setLoading(true);
        const result = await getOrders();
        setOrders(result);
        setError(null);
      } catch (err) {
        console.warn("Orders API not available yet:", err.message);
        setOrders([]);
        setError(null); // stay silent, don't block the form
      } finally {
        setLoading(false);
      }
    };
    fetchOrders();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">Order Management</h1>
      <p className="text-gray-500 mt-2 mb-6">
        Sales orders and order tracking will appear here.
      </p>

      {loading && (
        <p className="text-gray-500 text-sm mb-4">Loading orders...</p>
      )}
      {!loading && orders.length === 0 && (
        <p className="text-gray-400 text-xs mb-4">
          No existing orders yet — create one below.
        </p>
      )}

      <SalesOrderForm />
    </div>
  );
}

import SalesOrderForm from "../components/SalesOrderForm";

export default function Orders() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">Order Management</h1>
      <p className="text-gray-500 mt-2 mb-6">
        Sales orders and order tracking will appear here.
      </p>

      <SalesOrderForm />
    </div>
  );
}

import { Outlet, Link } from "react-router-dom";

export default function DashboardLayout() {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-56 bg-gray-900 text-white p-4">
        <h2 className="text-lg font-bold mb-6">ERP Dashboard</h2>
        <nav className="flex flex-col gap-3">
          <Link to="/" className="hover:text-blue-400">
            Inventory
          </Link>
          <Link to="/procurement" className="hover:text-blue-400">
            Procurement
          </Link>
          <Link to="/orders" className="hover:text-blue-400">
            Orders
          </Link>
          <Link to="/shipments" className="hover:text-blue-400">
            Shipments
          </Link>
        </nav>
      </aside>

      {/* Page content */}
      <main className="flex-1 bg-gray-50">
        <Outlet />
      </main>
    </div>
  );
}

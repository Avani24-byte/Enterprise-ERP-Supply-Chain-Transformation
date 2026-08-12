import { Outlet, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function DashboardLayout() {
  const { logout } = useAuth(); // ✅ this line was missing

  return (
    <div className="w-full md:w-56 bg-gray-900 text-white p-4">
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

        <button
          onClick={logout}
          className="mt-8 text-sm text-red-400 hover:text-red-300"
        >
          Logout
        </button>
      </aside>

      {/* Page content */}
      <main className="flex-1 bg-gray-50">
        <Outlet />
      </main>
    </div>
  );
}

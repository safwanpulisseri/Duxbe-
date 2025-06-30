export enum Role {
    admin = "admin",
    staff = "staff",
}

export type Employee = {
    employee_id: string;
    email: string;
    name: string;
    org_id: string;
    phone?: string;
    code?: string;
    image?: string;
    role?: Role;
    employee_role_ids?: string[];
    business_ids?: string[];
    employee_branches_view?: EmployeeAccess[];
};

export type EmployeeAccess = {
    employee_id: string;
    business_id: string;
    name: string;
};

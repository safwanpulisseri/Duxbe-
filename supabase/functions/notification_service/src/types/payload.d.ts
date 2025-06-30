type InsertPayload<T> = {
    type: "INSERT";
    table: string;
    schema: string;
    record: T;
    old_record: null;
};
type UpdatePayload<T> = {
    type: "UPDATE";
    table: string;
    schema: string;
    record: T;
    old_record: T;
};
type DeletePayload<T> = {
    type: "DELETE";
    table: string;
    schema: string;
    record: null;
    old_record: T;
};

export type Payload<T> = InsertPayload<T> | UpdatePayload<T> | DeletePayload<T>;

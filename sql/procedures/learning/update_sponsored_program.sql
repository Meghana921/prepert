delimiter //
create procedure update_sponsored_program(
	IN in_program_id BIGINT,
    IN in_slots INT,
    IN in_cancelled BOOLEAN
)
begin
	START TRANSACTION;
    
	update dt_program_sponsorships set 
		seats_allocated = in_slots , is_cancelled = in_cancelled
	where learning_program_tid = in_program_id;
	commit;
end//
delimiter ;
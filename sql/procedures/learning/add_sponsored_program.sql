delimiter //
create procedure add_sponsored_program(
	IN in_program_id BIGINT,
    IN in_creator_id BIGINT,
    IN in_slots INT
)
begin
	START TRANSACTION;
	INSERT INTO dt_program_sponsorships (
		company_user_tid,
		learning_program_tid,
		seats_allocated
	) VALUES (
		in_creator_id,
		in_program_id,
		in_slots
	);
	commit;
end//
delimiter ;